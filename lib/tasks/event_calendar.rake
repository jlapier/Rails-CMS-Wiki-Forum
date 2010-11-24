if defined? EventCalendar::Engine
  namespace "event_calendar" do

    # Migrate after schema in case there is no engine schema: at least we'll get the migrations.
    task :install => %w{assets db:schema db:migrate db:migrate:seed}

    desc "Import event_calendar's assets and new db migrations"
    task :update => %w{assets db:migrate}

    namespace :db do #

      def host_migration(new_migration_name, &block)
        require 'rails/generators/active_record'
        db_migrate = File.join Rails.root, *%w{db migrate}
        mkdir_p db_migrate unless File.exists? db_migrate

        # TODO Kill after https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4412
        sleep 1 # wait for timestamp to change.

        migration_number = ActiveRecord::Generators::Base.next_migration_number(db_migrate)
        new_migration = File.join db_migrate, "#{migration_number}_#{new_migration_name}.rb"
        tmp_migration = File.join Dir::tmpdir, "#{migration_number}_#{new_migration_name}.rb"

        File.open(tmp_migration, "w") do |f|
          f << block.call
        end

        cp tmp_migration, new_migration
      end

      def import_migration(original_file, new_migration_name, &block)
        host_migration new_migration_name do
          block.call File.read original_file
        end
      end

      desc "Import event_calendar's new db migrations"
      task :migrate do
        require 'rails/generators/active_record'
        db_migrate = File.join Rails.root, *%w{db migrate}

        # Consider the set of engine migrations, in chronological order.
        migrations = Dir[File.join EventCalendar::Engine.root, *%w{db migrate [0-9]*_*.rb}]
        migrations.sort!

        # See if the host already has a schema migration.
        last_migration_in_schema = migrations.reverse.detect do |migration|
          name = File.basename(migration).match(/\d+_(.*)\.rb/)[1]
          Dir[File.join(db_migrate, "[0-9]*_event_calendar_schema_after_#{name}.rb")].any?
        end

        # If so, do not import any migrations implied by the schema
        # (recall slice! *removes* the indicated range, leaving the rest.)
        migrations.slice! 0..migrations.index(last_migration_in_schema) if last_migration_in_schema

        # Of the remainder
        migrations.each do |old_migration|
          old_name = File.basename(old_migration).match(/\d+_(.*)\.rb/)[1]
          new_name = "event_calendar_#{old_name}"

          # Skip this single migration if we already have it
          next if Dir[File.join(db_migrate, "[0-9]*_#{new_name}.rb")].any?

          import_migration old_migration, new_name do |migration_source|
            migration_source.gsub "class #{old_name.camelize}", "class #{new_name.camelize}"
          end
        end
      end

      desc "Import event_calendar's schema as a db migration"
      task :schema do
        schema = File.join EventCalendar::Engine.root, *%w{db schema.rb}
        if File.exist? schema
          migrations = Dir[File.join EventCalendar::Engine.root, *%w{db migrate [0-9]*_*.rb}]
          latest_migration = migrations.sort.last

          migration_name = if latest_migration
            latest_migration_name = File.basename(latest_migration).match(/^\d+_(.+)\.rb$/)[1]
            "event_calendar_schema_after_#{latest_migration_name}"
          else
            "event_calendar_schema"
          end

          import_migration schema, migration_name do |schema_source|
            # Strip schema declaration
            schema_source.gsub! /\A.*^ActiveRecord::Schema.define\(:version => \d+\) do/m, ''
            schema_source.strip!.gsub!(/^end\Z/m, '').strip!

            # Indent everything 2 and strip trailing white space
            schema_source.gsub!(/^/, '  ').gsub!(/[\t ]+$/, '')

            # Wrap with migration class declaration
<<-EOF
class #{migration_name.camelize} < ActiveRecord::Migration
  def self.up
  #{schema_source}
  end
end
EOF
          end
        end
      end

      task "migrate:seed" do
        migration_name = "event_calendar_seed"
        if File.exist? File.join(EventCalendar::Engine.root, 'db', 'seeds.rb')
          host_migration migration_name do
<<-EOF
class #{migration_name.camelize} < ActiveRecord::Migration
  def self.up
    load File.join(EventCalendar::Engine.root, 'db', 'seeds.rb')
  end
end
EOF
          end
        end
      end

      desc "Load event_calendar's seed data"
      task :seed => :environment do
        seed_file = File.join(EventCalendar::Engine.root, 'db', 'seeds.rb')
        load(seed_file) if File.exist?(seed_file)
      end

    end

    desc "Link (or copy) event_calendar's static assets"
    task :assets, [:copy] => :environment do |t, args|
      engine_asset_path = File.join(
        Rails.application.paths.public.to_a.first,
        EventCalendar::Engine::ASSET_PREFIX)

      rm_rf engine_asset_path
      host_asset_path = EventCalendar::Engine.paths.public.to_a.first

      link = lambda do
        begin
          ln_s host_asset_path, engine_asset_path
          true
        rescue NotImplementedError
          false
        end
      end

      copy = lambda { cp_r host_asset_path, engine_asset_path }

      not args[:copy] and link.call or copy.call
    end

  end

  namespace :engines do

    desc "Load seed data from all engines"
    task "db:seed" => "event_calendar:db:seed"

    desc "Import new migrations from all engines"
    task "db:migrate" => "event_calendar:db:migrate"

    desc "Link (or copy) static assets from all engines"
    task :assets, [:copy] => "event_calendar:assets"

    desc "Import assets and new db migrations from all engines"
    task :update => "event_calendar:update"

  end

  task "db:seed" => "engines:db:seed"
end

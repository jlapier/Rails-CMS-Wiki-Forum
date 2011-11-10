class Participator
  def self.create!(attendee_hash)    
    event_id = attendee_hash.delete :event_id
    attendees = []
    attendee_hash.each do |participant_class, participant_ids|
      participant_class = participant_class.to_s.classify.constantize
      if Participant.types.include?(participant_class)
        participant_ids.each do |participant_id|
          next if participant_id.blank? || participant_class.blank?
          attendees << Attendee.create!({
            :event_id => event_id,
            :participant_id => participant_id,
            :participant_type => participant_class
          })
        end
      end
    end
    attendees
  end
end
module UsersHelper
  def color_by_group_status(status)
    case status
    when 1 then 'darkgreen'
    when -1 then 'darkred'
    else
      'darkblue'
    end
  end
end

class Notifier < ActionMailer::Base
  

  def invitation(punter, sent_at = Time.now)
    subject    "[TLD] You've been invited to The Longest Day"
    recipients punter.email_with_name
    from       'site@thelongestday.net'
    sent_on    sent_at
    
    body       :invitee => punter
  end

end

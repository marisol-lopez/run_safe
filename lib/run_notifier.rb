class RunNotifier
  def initialize(run_id)
    @run_id = run_id
  end

  def run_not_ended
    puts ">>> In run_not_ended, time is #{Time.now}"
    run = Run.find(@run_id)

    # sleep(@delayed_time.minutes)
    run_end_time = Time.parse(run.end_time)
    time_now = Time.now
    puts "My run status is #{run.status}"
    if time_now > run_end_time && run.status == "pending"
      puts "****I'm in the conditional, so it's been met****"
      client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
      puts "#{run.contact.contact_phone_number}"

      phone_number = "+1 " + run.contact.contact_phone_number
      puts "i'm in the middle of the conditional"

      second_message_to_send = "Hey! Please don't be alarmed but " + run.user.username + " hasn't ended their run and it's past their designated end time of: "  + run.end_time + ". Maybe try to give them a call to check in?"

      message = client.messages.create from: '+1 562-320-8726', to: phone_number, body: second_message_to_send
      puts "Sent message: #{second_message_to_send}, status: #{message.status}"
    else
      puts "I didn't meet the conditional"
      puts "My run status is: #{run.status}"
    end
  end
end

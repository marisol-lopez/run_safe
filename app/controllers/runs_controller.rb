class RunsController < ApplicationController


  skip_before_action :verify_authenticity_token

  def index
    @runs = Run.all
    if @runs.empty?
      render json: { error: "No runs found" }, status: :not_found
    else
      Rails.logger.debug("I printed something to the console")
      render json: @runs.as_json(only: [:id, :location, :status, :user_id, :contact_id]), status: :ok
    end
  end

  def create
    if User.exists?(username: data_params[:username])
      @user = User.find_by(username: data_params[:username])
    else
      @user = User.create(username: data_params[:username])
    end
    if Contact.exists?(contact_name: data_params[:contact_name])
      @contact = Contact.find_by(contact_name: data_params[:contact_name])
    else

      @contact = Contact.create(contact_name: data_params[:contact_name], contact_phone_number: data_params[:contact_phone_number])
    end
    if Run.exists?(user_id: @user.id, status:"pending")
      puts "sorry cannot create another run, without ending the pending one you have"
    else
      puts "Time Run was created: #{Time.now}"
      @run = Run.create(location: data_params[:location], end_time: data_params[:end_time], status: "pending", user_id: @user.id, contact_id: @contact.id )
      self.notify
      # time_now = Time.now#.getgm
      end_time = Time.parse(@run.end_time)
      # trying to get aws rails to read time in utc for delayed_job run_at
      end_time += 7 * 60 * 60
      puts "time the run was created: #{Time.now}"
      puts "end time: #{end_time}"
      # @delayed_time = (((end_time - time_now)/60) + 1).ceil
      # puts "delayed_time: #{@delayed_time}"
      notifier = RunNotifier.new(@run.id)
      notifier.delay(run_at: end_time).run_not_ended
      puts "I made it past notifier.delay"

    end
  end

  def notify
    client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
    @phone_number = "+1 " + @contact.contact_phone_number
    @message_to_send = "Hey! " + @user.username + " just started a run at " + @run.location + " and expects to be finished by " + @run.end_time
    message = client.messages.create from: '+1 562-320-8726', to: @phone_number, body: @message_to_send
    render plain: message.status
  end

  def end_run
    @user = User.find_by(username: params[:username])
    @contact = Contact.find_by(contact_name: params[:contact_name])
    if Run.exists?(user_id: @user.id, status:"pending")
      @run = Run.find_by(user_id: @user.id, status:"pending")
      @run.status = "completed"
      @run.save
    end
  end

  # def run_not_ended
  #   puts ">>> In run_not_ended, time is #{Time.now}"
  #   # sleep(@delayed_time.minutes)
  #   run_end_time = Time.parse(@run.end_time)
  #   time_now = Time.now
  #   if time_now > run_end_time && @run.status = "pending"
  #     client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
  #     @phone_number = "+1 " + @contact.contact_phone_number
  #     puts "i'm in the middle of the conditional"
  #     @second_message_to_send = "Hey! Please don't be alarmed but " + @user.username + " hasn't ended their run and it's past their designated end time of: "  + @run.end_time + ". Maybe try to give them a call to check in?"
  #     message = client.messages.create from: '+1 562-320-8726', to: @phone_number, body: @second_message_to_send
  #     render plain: message.status
  #   end
  # end


  # set timer with the end_time as seconds and then run this method at this time
  # need to account for timezone
  # time_now = Time.now
  # end_time = Time.parse(@run.end_time)
  # delayed_time = (((end_time - time_now)/60) + 1).ceil
  # .delay(run_at: delayed_time.minutes.from_now)

  # HELP will need to figure out how to access the current user / run???
  # will have something to do with a timer that will compare Time.now(current time) with the end_time associated with the run
  # then I will say something like
  # if run.end_time > Time.now && run.status = "pending"
  # self.notify_late_text #which will send the textmessage

  # this will be used for when I get the timer thing to work for sending the second text message
  # def notify_late_text
  #   time_now3 = Time.now
  #   puts "the time i made it into notify_late_text: #{time_now3}"
  #   puts "I'm in notify late text"
  #   client = Twilio::REST::Client.new Rails.application.secrets.twilio_account_sid, Rails.application.secrets.twilio_auth_token
  #   @phone_number = "+1 " + @contact.contact_phone_number
  #   @second_message_to_send = "Hey! Please don't be alarmed but " + @user.username + " hasn't ended their run and it's past their designated end time of: "  + @run.end_time + ". Maybe try to give them a call to check in?"
  #   message = client.messages.create from: '+1 562-320-8726', to: @phone_number, body: @second_message_to_send
  #   render plain: message.status
  # end


  # this would be for the second text message that was sent
  # def method_to_check_if_run_was_ended
  #   if Run.User.find_by(username: data_params[:username])
  #   end
  # if the user has a run with a status of pending and the time associated with their run has passed then send another text message to their designated contact
  # end
  # should be able to set a timer in rails or a gem
  # just leave it running if you've changed the status to completed

  private

  def data_params
    params.permit(:username, :contact_name, :contact_phone_number, :location, :end_time, :status)
  end
end

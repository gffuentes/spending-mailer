require 'mail'

def csrf_parse(out)
	/.{44}(?=(\" name=\"_csrf\"))/.match(out)
end

def session_parse(out)
	/.{64}(?=(; path=\/; HttpOnly; secure))/.match(out)
end

def sign_in 
	#Load initial sign-in page to get auth
	req = Net::HTTP.get_response(@sign_in)
	csrf = csrf_parse(req.body)
	session = session_parse(req['set-cookie'])
	puts "_csrf: #{csrf}"
	puts "session: #{session}"
	#Actually sign in using same auth. Also need to get new auth.
	p_req = Net::HTTP::Post.new(@sign_in)
	p_req.set_form_data('username' => ENV['S_USERNAME'], 'password' => ENV['S_PASSWORD'], '_csrf' => csrf)
	p_req['Cookie'] = "_simple_session=#{session}"
  post = Net::HTTP.start(@sign_in.hostname,@sign_in.port, :use_ssl => true) {|http|
    http.request(p_req) 
  }
  session_parse(post['Set-Cookie'])
end

def get(url,session)
  req = Net::HTTP::Get.new(URI(url))
  req['Cookie'] = "_simple_session=#{session}"
  request = Net::HTTP.start(URI(url).hostname,URI(url).port,:use_ssl => true) {|http|
    http.request(req)
  }
  JSON.parse(request.body)
end

def days_ago(day)
	@transactions_array = []
  @transactions_json["transactions"].each do | t |
    if t["times"]["when_recorded_local"].include?((DateTime.now - day).strftime('%Y-%m-%d')) && t["bookkeeping_type"] == "debit"
      @transactions_array << t
    end
  end
  return @transactions_array  
end

def deliver(html)
  mail = Mail.new(:from => ENV['G_USERNAME'], :to => ENV['G_USERNAME'], :subject => "Your Spend Report! #{Time.now.strftime('%Y-%m-%d')}")
  mail.html_part = Mail::Part.new(:content_type => 'text/html; charset-UTF-8', :body => html)
  mail.delivery_method :smtp, {:address => 'smtp.gmail.com',
    :port => '587',
    :user_name => ENV['G_USERNAME'],
    :password => ENV['G_PASSWORD'],
    :authentication => :plain,
    :enable_starttls_auto => true }
  mail.deliver!
end
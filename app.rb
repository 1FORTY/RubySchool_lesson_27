require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def get_db
  db = SQLite3::Database.new 'barbershop.db'
  db.results_as_hash = true
  return db
end

configure do
  @db = get_db
  @db.execute "create table if not exists 'users' ('id' intenger primary key autoincrement, 'username' text, 'phone' intenger, 'datestamp' text, 'barber' text, 'color' text);"
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/about' do
	erb :about
end

get '/visit' do
	erb :visit
end

post '/visit' do

	@username = params[:username]
	@phone = params[:phone]
	@datetime = params[:datetime]
	@barber = params[:barber]
	@color = params[:color]

  # Validation for visit.erb
  validate = {
      username: "Введите имя",
      phone: "Введите телефон",
      datetime: "Введите время"
  }

  @error = validate.select {|key,_| params[key] == ""}.values.join(", ")

  if @error != ''
    return erb :visit
  end

  @db = get_db
  @db.execute "insert into users(name, phone, datestamp, barber, color) values (?, ?, ?, ?, ?)", [@username, @phone, @datetime, @barber, @color]

	erb "OK, username is #{@username}, #{@phone}, #{@datetime}, #{@barber}, #{@color}..."

end

get '/contacts' do
  erb :contacts
end

post '/contacts' do
  @password = params[:pass]
  @email = params[:email]

  validation = {
      password: "Вы не ввели пароль",
      email: "Вы не ввели потовый адрес"
  }

  validation.each do |key, value|
    if params[key] == ''
      @error = value
    end

    if @password.size < 6
      @error = 'Ваш пароль слишком простой'
    elsif !@email.include?('@')
      @error = 'Вы ввели не почту'
    end
  end

  if @error != ''
		return erb :contacts
  end

  erb "Спасибо, мы получили ваши данные. Пароль: #{@password} и почта: #{@email}"
end

get '/showusers' do
  @db = get_db
  @result = @db.execute "select * from users order by id desc"

  erb :showusers
end
#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'lepra.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
		id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, 
		created_date DATE,
		content TEXT
	)'
end

get '/' do
# список постов в порядке убывания
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index			
end

get '/new' do
  erb :new
end

post '/new' do	
	content = params[:content]
# проверка параметров
	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end
# вставка данных с формы
	@db.execute 'insert into Posts (created_date, content) values (datetime(),?)',[content]

# на главную
	redirect to('/')
end

# вывод информации о посте
get '/details/:post_id' do
	post_id = params[:post_id]
	results = @db.execute 'select * from Posts where id = ?', [post_id] 
	@row = results[0]
	erb :details
end
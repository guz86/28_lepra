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
		content TEXT,
		name TEXT
	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		id INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL  UNIQUE, 
		created_date DATE,
		content TEXT,
		post_id integer
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
	name = params[:name]
# проверка параметров
	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end
# вставка данных с формы
	@db.execute 'insert into Posts (created_date, content, name) values (datetime(),?,?)', [content, name]

# на главную
	redirect to('/')
end

# вывод информации о посте
get '/details/:post_id' do
	post_id = params[:post_id]
	results = @db.execute 'select * from Posts where id = ?', [post_id] 
	@row = results[0]

# комментарии для поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	@db.execute 'insert into Comments (created_date, content, post_id) 
				values (datetime(),?,?)', [content, post_id]

	redirect to('/details/' + post_id)
end
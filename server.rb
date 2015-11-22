require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "movies")
    yield(connection)
  ensure
    connection.close
  end
end

def movie_top_page
  results = db_connection do |conn|
    conn.exec("SELECT movies.title, movies.rating,
    movies.year, movies.id, genres.name AS genre,
    studios.name AS studio
      FROM movies
      JOIN genres
      ON (movies.genre_id = genres.id)
      JOIN studios
      ON (movies.studio_id = studios.id)
      ORDER BY movies.title, movies.year;")
  end
end

def movie_detail(movies_id)
  results = db_connection do |conn|
    sql_query = "SELECT movies.title, genres.name AS genre,
    studios.name AS studio, actors.id,
    actors.name AS actor, cast_members.character AS character
      FROM movies
      JOIN genres
      ON (movies.genre_id = genres.id)
      JOIN studios
      ON (movies.studio_id = studios.id)
      JOIN cast_members
      ON (cast_members.movie_id = movies.id)
      JOIN actors
      ON (actors.id = cast_members.actor_id)
      WHERE movies.id = $1
      ORDER BY actors.name"
      conn.exec_params(sql_query, [movies_id])
  end
end

def actors
  results = db_connection do |conn|
    conn.exec("SELECT actors.id, actors.name AS actor
      FROM actors
      ORDER BY actors.name;")
    end
end

def actor_detail(actor_id)
  results = db_connection do |conn|
    sql_query = "SELECT actors.name AS actor,
      movies.id, movies.title, cast_members.character
      FROM actors
      JOIN cast_members
      ON (cast_members.actor_id = actors.id)
      JOIN movies
      ON (movies.id = cast_members.movie_id)
      WHERE actors.id = $1
      ORDER BY movies.title"
      conn.exec_params(sql_query, [actor_id])
  end
end

get "/" do
  redirect '/movies'
end

get "/movies" do
  @movie_table = movie_top_page
  erb :'movies/index'
end

get "/movies/:id" do
  @movie_detail = movie_detail(params[:id])
  @actor_detail = actor_detail(params[:id])
  erb :'movies/show'
end

get "/actors" do
  @actors = actors
  erb :'actors/index'
end

get '/actors/:id' do
  @actor_detail = actor_detail(params[:id])
  erb :'actors/show'
end

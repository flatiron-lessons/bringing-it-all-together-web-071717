require "pry"

class Dog
	def initialize(id: nil, name:, breed:)
		@name = name
		@breed = breed
		@id = id
	end

	attr_accessor :name, :breed, :id

	def self.create_table
		sql = <<-SQL
			CREATE TABLE IF NOT EXISTS dogs (
			id INTEGER PRIMARY KEY,
			name TEXT,
			breed TEXT
			)
		SQL
		DB[:conn].execute(sql)
	end

	def self.drop_table
		DB[:conn].execute("DROP TABLE IF EXISTS dogs")
	end

	def save
		sql = <<-SQL
			INSERT INTO dogs (name, breed) VALUES (?, ?)
		SQL
		DB[:conn].execute(sql, name, breed)
		@id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
		self
	end

	def self.create(attributes)
		# attributes.each {|k,v| self.send(("#{k}="), v)}
		dog = Dog.new(name: attributes[:name], breed: attributes[:breed])
		dog.save
	end

	def self.new_from_db(row)
		new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
	end

	def self.find_by_id(id)
		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE id = ?
		SQL
		results = DB[:conn].execute(sql, id)
		row = results[0]
		self.new_from_db(row)
	end

	def self.find_by_name(name)
		sql = <<-SQL
		SELECT * 
		FROM dogs
		WHERE name = ?
		SQL

		results = DB[:conn].execute(sql, name)
		row = results[0]
		self.new_from_db(row)
	end

	def self.find_or_create_by(attributes)

		sql = <<-SQL
			SELECT *
			FROM dogs
			WHERE name = ?
			AND breed = ?
		SQL

		results = DB[:conn].execute(sql, attributes[:name], attributes[:breed])

		if results.empty?
			self.create(attributes)
		else
			self.new_from_db(results[0])
		end
	end

	def update
		sql = <<-SQL
			UPDATE dogs
			SET name = ?, breed = ?
			WHERE id = ?
		SQL
		DB[:conn].execute(sql, name, breed, id)
	end

end
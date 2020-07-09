require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]
  attr_accessor :name, :grade
  attr_reader :id

  def initialize(name, grade, id = nil)
    @name, @grade, @id = name, grade, id
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT
      )
    SQL
    
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS students
    SQL
    
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade) 
        VALUES (?, ?)
      SQL
  
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def self.create(name, grade)
    new_student = Student.new(name, grade)
    new_student.save
  end

  def self.new_from_db(row)
    student = self.new(row[1], row[2], row[0])
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students
      WHERE students.name = ?
    SQL
    student = DB[:conn].execute(sql, name).first
    self.new(student[1], student[2], student[0])
  end

  def update
    sql = <<-SQL
      UPDATE students SET name = ?, grade = ? WHERE students.id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

end

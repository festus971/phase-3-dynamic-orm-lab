require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  def initialize(options={})
    options.each do |property,value|
        self.class.attr_accessor (property.to_sym)
        self.send("#{property}=",value)
    end
end

def self.table_name
    self.to_s.pluralize.downcase
end

def self.column_names
    DB[:conn].results_as_hash
    info=DB[:conn].execute("PRAGMA table_info('#{self.table_name}')")
    (info.map {|column| column['name']}).compact
end

def table_name_for_insert
    self.class.table_name
end

def col_names_for_insert
    self.class.column_names.delete_if{|name| name=="id"}.join(", ")
end

def values_for_insert
    values=[]
    self.class.column_names.each do |name|
        values << "'#{send(name)}'" unless send(name).nil?
    end
    values.join(", ")
end

def save
    DB[:conn].execute("INSERT INTO '#{table_name_for_insert}'(#{col_names_for_insert}) VALUES (#{values_for_insert})")
    self.id=DB[:conn].execute("SELECT last_insert_rowid() FROM '#{table_name_for_insert}'")[0][0]
end

def self.find_by_name(name) 
    DB[:conn].execute("SELECT * FROM '#{table_name}' ")
end[0]

def self.find_by(property)
    property.map do |prop,value|
        query="SELECT * FROM #{table_name} WHERE #{prop}='#{value}'"
        DB[:conn].execute(query)
    end[0]
end

end
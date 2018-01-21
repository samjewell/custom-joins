require "pry"
require "byebug"

class Person < ActiveRecord::Base
  belongs_to :location
  belongs_to :role
  belongs_to :manager, class_name: "Person", foreign_key: :manager_id
  has_many :employees, class_name: "Person", foreign_key: :manager_id

  def self.without_remote_manager
    joins(<<-SQL).
      LEFT JOIN people managers
        ON managers.id = people.manager_id
    SQL
    where(<<-SQL)
      managers.location_id = people.location_id
        OR managers.id IS NULL
    SQL
  end

  def self.order_by_location_name
    joins(:location).order("locations.name")
  end

  def self.with_employees
    joins(:employees).distinct
  end

  def self.with_local_coworkers
    joins(location: :people).where("people_locations.id != people.id").distinct
  end
end

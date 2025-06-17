require "foobara/local_files_crud_driver"

crud_driver = Foobara::LocalFilesCrudDriver.new(multi_process: true)
Foobara::Persistence.default_crud_driver = crud_driver

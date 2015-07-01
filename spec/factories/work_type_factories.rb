FactoryGirl.define do
  
  #Create a WorkType object
  factory :work_type, class: WorkType do
    registered_name "FactoryWork"
    display_name "Factory Work"
    is_type_of "BiblioWork"
  end
  
end

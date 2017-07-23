Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'runs', to: 'runs#create'
  # patch 'runs', to: 'runs#update'
  post 'runs/notify' => 'runs#notify'
  post 'runs/end_run', to: 'runs#end_run'
  # resources :run_not_ended
  post 'runs/run_not_ended', to: 'runs#run_not_ended'
  # post 'runnotifier/run_not_ended', to: 'runnotifier/run_not_ended'



end

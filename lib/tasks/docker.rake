# lib/tasks/docker.rake

namespace :docker do
    desc "Запустить Docker Compose в фоне"
    task :up do
      sh "docker-compose up -d"
      sh "docker ps"
    end
  
    desc "Остановить Docker Compose и удалить тома"
    task :down do
      sh "docker-compose down -v"
    end
  
    desc "Пересобрать образы и запустить контейнеры"
    task :rebuild do
      sh "docker-compose build"
      sh "docker-compose up -d"
    end
  end
  
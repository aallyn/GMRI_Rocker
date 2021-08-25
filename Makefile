dropbox_connect:
	echo "python3 /mnt/volume_nyc1_01/dropbox.py start"

up: down
	docker-compose up -d --build
	docker-compose logs -f

down:
	docker-compose down

logs:
	docker-compose logs -f

prune:
	docker volume rm $(shell docker volume ls -qf dangling=true)
	docker system prune -a
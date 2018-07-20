.PHONY: install

# Start container and install Symfony
install:
	@if [ ! -d "symfony" ]; then \
		docker-compose exec -u 1000 php-fpm composer create-project symfony/website-skeleton /var/www/symfony 4.1.*; \
		echo "---- Installation finished ----"; \
		echo "---- Go to http://localhost ----"; \
	else \
		echo "---- Symfony (/symfony) directory exists. Installation aborted ----"; \
	fi
initialize:
	docker-compose up -d
	make install
cc:
	docker-compose exec -u 1000 php-fpm /var/www/symfony/bin/console cache:clear --env=$(env)

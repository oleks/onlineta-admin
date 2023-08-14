HOST=mist
JUMPHOST=mist@os236.hpc.ku.dk

.PHONY: create_coure
ifdef NAME
ifdef URL
ifdef UID
ifdef PROXY_PORT
ifdef GH_USERS
create_course:
	mkdir -p courses/$(NAME)/build
	m4 \
	  -DCOURSE_NAME=$(NAME) \
	  -DCOURSE_URL=$(URL) \
	  -DCOURSE_PROXY_PORT=$(PROXY_PORT) \
	  nginx.conf.m4 \
	  > courses/$(NAME)/build/nginx.conf
	m4 \
	  -DCOURSE_NAME=$(NAME) \
	  -DCOURSE_PROXY_PORT=$(PROXY_PORT) \
	  testserver.service.m4 \
	  > courses/$(NAME)/build/testserver.service
	mkdir -p courses/$(NAME)/build/.ssh/
	rm -f courses/$(NAME)/build/.ssh/authorized_keys
	for user in $(GH_USERS); do \
	  curl -s https://github.com/$$user.keys \
	  >> courses/$(NAME)/build/.ssh/authorized_keys; \
	done
	ssh ubuntu@${HOST} 'sudo adduser --disabled-password --gecos GECOS --uid $(UID) $(NAME) && sudo usermod -aG docker $(NAME)'
	scp -r courses/$(NAME)/build/.* courses/$(NAME)/build/* ubuntu@${HOST}:$(NAME)
	ssh ubuntu@${HOST} 'cd $(NAME) && sudo mv nginx.conf /etc/nginx/sites-available/$(NAME) && sudo ln -s /etc/nginx/sites-available/$(NAME) /etc/nginx/sites-enabled/$(NAME) && sudo mv .ssh testserver.service /home/$(NAME)/'
	ssh ubuntu@${HOST} 'sudo chown -R $(NAME):$(NAME) /home/$(NAME)/.ssh'
	ssh ubuntu@${HOST} 'sudo -u $(NAME) /bin/bash -c "mkdir ~$(NAME)/uploads && chmod -R 700 ~$(NAME)/.ssh"'
	ssh ubuntu@${HOST} 'sudo certbot --nginx --agree-tos --non-interactive -m oleks@oleks.info -d $(URL)'	
	rsync --chmod=Do+rx,Fo+r -ave 'ssh -A -J${JUMPHOST}' --exclude='*~' --exclude='__pycache__' static share ${NAME}@${HOST}:~${NAME}/
	ssh ${NAME}@${HOST} share/build-index.sh
	ssh ubuntu@${HOST} 'sudo chown $(NAME):www-data /home/$(NAME) && sudo chown -R $(NAME):www-data /home/$(NAME)/static && sudo chmod -R g+x /home/$(NAME)/static'
endif
endif
endif
endif
endif

ifdef NAME
ifdef URL
del_course:
	ssh ubuntu@${HOST} 'sudo rm -rf /etc/nginx/sites-enabled/$(NAME) /etc/nginx/sites-available/$(NAME) /etc/letsencrypt/live/$(URL)/ && sudo deluser --remove-home $(NAME) && sudo systemctl reload nginx'
endif
endif

#create_course:
#	@echo Please provide missing variables:
#	@echo make NAME=... URL=... UID=... PROXY_PORT=... create_course

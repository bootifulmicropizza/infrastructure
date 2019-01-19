#!/bin/bash

if docker build -t iancollington/bootifulmicropizza_jenkins . ; then
	docker push iancollington/bootifulmicropizza_jenkins
fi

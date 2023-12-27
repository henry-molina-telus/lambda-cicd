FROM public.ecr.aws/lambda/nodejs:20

COPY ./src/index.js .
  
CMD [ "index.handler" ]
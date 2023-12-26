FROM public.ecr.aws/lambda/nodejs:18

COPY ./bootstrap/index.js .
  
CMD [ "index.handler" ]
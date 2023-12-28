# namuton-team-vitamin

2023 namuton team vitamin. expiration date check using barcode application

// 공공 API data fetch 하기

```

  const express =require('./config/express');
  const {logger} = require('./config/winston');
  const axios = require('axios');
  
  const apiKey = '1a204396d49c825';
  const apiUrl = 'http://openapi.foodsafetykorea.go.kr/api/' + apiKey + '/C005/xml/1/5/';
  const port = 3000;
  
  express().listen(port); 
  logger.info(`${process.env.NODE_ENV} - API Server Start At Port ${port}`);
  
  axios.get(apiUrl)
    .then(response => {
      console.log(response.data);
    })
    .catch(error => {
      console.error(error);
    });

```
  

#!/bin/bash
wget https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/samples/moviedata.zip
unzip moviedata.zip
python3 scripts/MoviesLoadData.py
rm moviedata.json 
rm moviedata.zip

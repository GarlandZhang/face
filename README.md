# README

Face identifies each unique person in all your photos and categorizes these photos by name. Powered by AI, Face uses Microsoft Face API to detect and recognize faces from photos which is then stored in Ruby's Active Storage local service for further processing (using ImageMagick, Face also creates a profile picture by cropping out the detected face of each person). Other features include: search functionality by name and mutual/common friendships. Sql3lite database was used to persist the many objects' relationships. 

Ruby version is 5.2

## How to use:
*DISCLAIMER: Must clone project; have not yet migrated sq3lite database to postgres, so cannot host on Heroku yet.
*DISCLAIMER(#2): If you're looking to see a pretty UI, you've come to the wrong place. 

Due to using a trial for Microsoft's Face API, my subscription will most likely be expired. If however it works:

- create a user
- upload images from your folder
- sit back and relax (it takes a while on trial mode..)
- voila! feast your eyes on the power of ai


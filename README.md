# README

Update: It's live! https://still-thicket-61571.herokuapp.com
  - Due to subscription API limits, please don't load too many images at once. I implemented a request recall cycle if the subscription limit is reached but Heroku times out after 30 seconds.
  - Will update with a new subscription key :)

Face is a machine powered web app to extract people and objects from your photos to categorize them by name. Face uses Microsoft Face API to detect and recognize faces from photos which are uploaded to the cloud using Imgur's API, so that photos can be accessed by URL (using ImageMagick, Face also creates a profile picture by cropping out the detected face of each person). Other features include: search functionality by name and mutual/common friendships. PostgreSQL database was used as a backend store. 

Ruby version is 5.2

## How to use:
Due to using a trial for Microsoft's Face API, my subscription will most likely be expired. If however it works:

- create a user
- upload images from your folder
- sit back and relax (it takes a while on trial mode..)
- rename people or keep as a hash then:
  - use the search bar to search by name or by object present in the photo!

## Examples:

### Dashboard
![Image of website](app/assets/images/face-website.png)

### Profile
![Image of profile](app/assets/images/profile.png)

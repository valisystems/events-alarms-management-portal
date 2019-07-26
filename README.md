# events-alarms-management-portal
Events and alarms management portal software

# Section : New site installation

## Files

1. Copy all files, except for the *.bak database backup file, from Release folder to root folder of the site


## Configuration

1. Inside root folder of the site, web.config file must be check and/or modified accordingly
  - Verify that 'DefaultConnection' parameter has the valid SQL connection parameters
parameters

![web_config_1](https://user-images.githubusercontent.com/53027462/61923045-cc564980-af8c-11e9-99c2-3cce154818d0.png)


## Security access rights

1. Use the following guide for the next step, https://support.microsoft.com/en-sg/help/325361/how-to-configure-security-for-files-and-folders-on-a-network-in-window
2. Ensure to give Full Control rights to user IIS_IUSRS for the following folders,
  - {root_folder_of_the_site}\Content\Images
  - {root_folder_of_the_site}\Content\Sample
  - {root_folder_of_the_site}\Content\TemplateCss
  - {root_folder_of_the_site}\Content\Voice
  - {root_folder_of_the_site}\Report
  - {root_folder_of_the_site}\Views\Templates


## SQL database, IMPORTANT!!! This only applies for fresh installation

1. Delete the current database, if it exists
2. Restore the database using *.bak database backup file found in the Release folder

![ssms_db_1](https://user-images.githubusercontent.com/53027462/61923041-cbbdb300-af8c-11e9-9fd9-f360a3f79785.png)
![ssms_db_2](https://user-images.githubusercontent.com/53027462/61923042-cbbdb300-af8c-11e9-9d9f-bf7d90ffcc85.png)
![ssms_db_3](https://user-images.githubusercontent.com/53027462/61923043-cc564980-af8c-11e9-8661-c44c37e9d3ef.png)
![ssms_db_4](https://user-images.githubusercontent.com/53027462/61923044-cc564980-af8c-11e9-8ccd-f74675731ffa.png)

## LVMonitor initialization

1. Open the site locally or remotely
2. Enter credentials if required
3. Locate Admin Config -> Settings page
4. Use ‘DB Reset' button, just in case, to initialize the database


## IIS setup

1.Application Pool
  - Use DefaultAppPool, set the following Advanced Settings
  - General
    - .NET CLR Version -> v4.0
    - Start Mode -> AlwaysRunning
  - CPU
    - Limit -> 0
    - LimitAction -> ThrottleUnderLoad
  - Process Model
    - Identity -> LocalSystem
    - Idle Time-out -> 0
  - Recycling
    - Disable Overlapped Recycle -> False
    - Disable Recycling for Configuration Changes -> False
    - Regular Time Interval -> 0

![iis_app_pool_1](https://user-images.githubusercontent.com/53027462/61923030-ca8c8600-af8c-11e9-85f5-b2b121f7f8a6.png)
![iis_app_pool_2](https://user-images.githubusercontent.com/53027462/61923033-ca8c8600-af8c-11e9-8e5d-1a497600913b.png)
![iis_app_pool_3](https://user-images.githubusercontent.com/53027462/61923034-ca8c8600-af8c-11e9-89e8-561f331a20c0.png)

2. Sites
  - Add Website
    - Specify site name
    - Select DefaultAppPool for Application Pool
    - Select the physical path for the site
  - Advanced Settings
    - Preload Enabled -> True

![iis_website_1](https://user-images.githubusercontent.com/53027462/61923035-cb251c80-af8c-11e9-8985-86807c4a6866.png)


# Section : Guide to LvMonitor Site

![site_login_1](https://user-images.githubusercontent.com/53027462/61923040-cbbdb300-af8c-11e9-88a9-111e835d1824.png)

1. Under Admin Config -> Settings, press DB Reset button to reset all database settings and copy required table values and files

![site_db_reset_1](https://user-images.githubusercontent.com/53027462/61923037-cb251c80-af8c-11e9-91b3-579100510e28.png)

## Application Config

### Facility Divisions

1. CDR Type - type of CDR used to accept CDR calls, wrong CDR type will lead to unregistered CDR's in the system
2. CDR Domain - domain of CDR used to accept CDR calls, wrong CDR domain will lead to unregistered CDR's in the system
3. PBX Domain - domain for hunt group call initiation from the EMS system
4. PBX User - user name for hunt group call initiation from the EMS system, must be admin type user
5. PBX User Password - password for the user
6. Device Discovery - Device discovery on the facility level, when enabled, all the devices registered with the device discovery will automatically have Facility set; Note: if device discovery enabled in multiple facilities, then the first one in the list will be automatically entered in the newly discovered devices, thus, it is best to use discovery on per-facility basis

![site_facility_1](https://user-images.githubusercontent.com/53027462/61923038-cb251c80-af8c-11e9-8147-a1e1662a688a.png)

### Floors

1. Assign floors to a specific facility


### Departments

1. List of departments includes list of rooms in each department, department for room is set in the Room user interface
2. To set a department, at least one floor must exist


### Rooms

1. To set a room, at least one floor must exist
2. Rooms can be imported using a csv file, format is as follows:

RoomNumber,FloorNumber,RoomDescription

Required fields are:
- Floor Number
- Room Number


### Device Type

1. Used for devices to create button types (groups)


### Device Type Control

1. Used for devices to create buttons
2. Maximum limit of controls per type is 8, this is a hardcoded number
3. Images selected are from the Image Catalog, category Control


### Device Actions

1. An action consists of three action triggers and one alarm cancel trigger
  - Action is initially triggered by the Device Type Control status Alarm. An action trigger has the following parts, each listed and described below,
    - call after (seconds), delay after which the action trigger is executed, no delay is the value is empty
    - repeat every (min), recurring event, the action trigger will repeat every X minutes after the initial trigger is run. The accuracy is to seconds, meaning if the initial event ran at 19:05:52, with the delay set to 0 seconds and repeat set to 1 minute, then the next event will run at 19:07:00 (rounded to whole minutes)
    - type GET or POST, url method. For get request, query parameters are specified within a URL field, for post request, query parameters are specified in the Data field
    - URL field can contain any valid URL request
    - Data field is ONLY field if the request is set to POST, and is set to any valid Data Field request, ie: JSON, Text, XML etc
  - An alarm cancel trigger is similar to the action triggers, except that it does not have a delay or a recurring parameters and it occurs when the Device Type Control receives the status Normal
2. Patterns can be used to fill in the URL or Data fields with valid information regarding the action Device, ie: <%Floor%> will get the floor value of the device executing the action call
3. Device actions have a URL generator, it has the following URL generating options,
  - Vodia
    - hidden static values are,
      - url page, ‘/remote_call.htm'
  - Vodia Hunt Group
    - hidden static values are,
      - url page, ‘/api/VodiaHuntGroupCall'
  - 3CX
    - hidden static values are,
      - url page, ‘/mc'
  - miDevices
    - hidden static values are,
      - url page, ‘/set.cgi'
  - Well Tech
    - hidden static values are,
      - url page, ‘/relay'
  - PortSip
    - hidden static values are,
      - url page, ‘/api/extensions/call'
  - miSip
    - hidden static values are,
      - url dir, ‘/urldebug/catch/'
  - Patient Station Stream
    - hidden static values are,
      - query parameter 'action', ‘stream'
  - Patient Station Image
    - hidden static values are,
      - query parameter 'action', ‘snapshot'
  - CCTV Camera Stream
    - hidden static values are,
      - query parameter 'authorization', ‘Basic%20d2ViOg=='
      - url page with automatically replaced camera_id parameter, ‘/cameras/{camera_id}/video'
  - CCTV Camera Image
    - hidden static values are,
      - query parameter 'authorization', ‘Basic%20d2ViOg=='
      - url page with automatically replaced camera_id parameter, '/cameras/{camera_id}/image'

Note: Call After delay is relative to the previous action trigger within the action, for example if Action Trigger 1 Call After = 5 seconds and Action Trigger 2 Call After = 15 seconds, then the second action trigger will be executed 20 seconds after the Action has begun executing

Note: We can easily configure a self-canceling alarm using a delay parameter and in the URL field include the alarm URL of the calling device with the alarm status set to Normal. Meaning, after X seconds an alarm trigger will initiate a call to cancel the alarm.


### Device List

1. Devices can be added by one of two ways,
  - Creating a device from UI
  - Using Device Discovery
  - Importing a device list with csv, format as follows

DeviceType,Department,RoomNumber,DeviceCode,DeviceName,DeviceDescription

Required fields are:
- Room Number
- Department
- Device Type
- Device Code

A. If the Device Name is not set, it will take the Device Code value
B. If the Device Description is not set, it will be set to a static value

  Using the Device Discovery, it must be enable on the Facility (Application Config -> Facility Divisions) or the Application level (Admin Config -> Settings)

2. When image is not specified when creating a device from UI, a default image will be used from the image catalog of type Device
3. The device must be attached to a Department and Room
4. Device can contain Device Actions, one control button is attached to one or more actions


### Resource Text Type

1. Type of resource text


### Resource Text

1. Resource text to send in Alarms and Device Actions


### Resource TTS

1. Text-to-speech recordings to be able to use in Alarms and Device Actions
2. Example of URL/Data Resource TTS can be found in Device Record Test, when user selects Resource TTS
3. When alarm is initiated with a resource TTS, the speech audio will be played on the monitor

Note: Speech audio on the monitor must be worked on, many alarms with audio are not played properly. Must implement an audio queue on the backend


### Facility Alarm Screen

1. If the alarm screen is removed, and a user will try to open a monitor having cookies from the non-existing monitor, the cookies will be removed and the user will be re-directed to the selection of a Live Panel


## Admin Config

### Settings

1. Image File Types, define the allowed types of images to attach in the system
2. Max Image File Size, define the allowed image size limit to attach in the system
3. Default Page Size, define the page size for pages containing pagination
4. Enable Device Discovery application wide, in this case Facility will not be automatically entered when a new device or device control type is discovered
5. DB Reset, resets the entire database, indexes, returns it to the default state and completes Copy Default Files function
6. Delete Devices, etc, deletes the specified entries from the database
7. Delete Monitor Records, deletes all monitor records the the database
8. Insert Monitor Test Data, monitor records data is generated and inserted into the database. Note: sometimes a glitch with the time occurs, begin time > end time, and in the analytics the time is displayed as —h:--m:--s

### Device Discovery

1. Status at the top of the page will display whether Device Discovery is turned on or off, and if's turned on, on which level Facility or Application
2. User can copy the Link at the top of the page to use for sending device discovery requests
3. Devices will be discovered in several scenarios
  - the device does not exist by the BaseName (Device Code) parameter
  - the device Control Type Control (button) does not exist
4. When Device Type is assigned to an entry, upon saving the user must verify the number of existing Device Type Controls for the specific Device Type does not go over 8; otherwise, errors will occur in certain scenario. Of course, this is not a desired behaviour and must be reworked in the later releases


### URL Debugging

1. User can copy the link at the top of the page to use for sending debug request, this may be used to test the network connectivity to a specific network device, the parameters passed etc
2. This page will also accept invalid Device Discovery requests, invalid CDR requests
3. The page is refreshed automatically with each request, but due to the fact that the page is refreshed on each new request and not populated with new data in the background, some consecutive requests may not display and manual Refresh may be required


## Analytics

### Response

1. Hardware automatically selected as Device if none selected on Get Report or Export requests
2. Show Top, shows the top entries from the entire search list by sorted column, default sort column is Descending Date


### Response Summary

1. Similar to Response
2. Show Top, shows the top entries from the entire search list sorted by the response time


### CDR Calls

1. Similar to Response
2. Shows CDR calls registers on the PBX system setup under Facility section

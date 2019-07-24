# Change Log

## [2.3.0] - 05-05-2019
- Fixed bugs in the TTS audio play on the monitor
- Completed implementation of Response and Response Summary Analytics, added chart support, filtering, export functionality
- Added more pre-defined HTML/CSS templates for Monitor cards
- Fixed bugs in the user role module

## [2.2.0] - 03-21-2019
- Added API to receive CDR calls
- Implemented CDR call storing mechanism to store all the required call information
- Started to implement the analytics interfaces, there are three major components, Response Analytics, Response Summary Analytics and CDR Call Analytics, at the time only basic information is presented as a table view with an ability to filter by the date period
- Fixed bugs in the PBX management
- Fixed bugs in the Resource TTS management

## [2.1.0] - 02-05-2019
- Integrated Device Action Template into the Device management, each device is able to support an unlimited amount of Device Actions. Device Action Template is attached to a specific Device Type Control of a Device, meaning that different Device Type Control generated events can invoke different Device Actions
- Implemented PBX management, created Vodia and PortSip interfaces. Added PBX setup for each Facility structure to provide individual PBX for each Facility. In the next release CDR collection mechanism will be added to store CDR calls and provide analytics directly from the system

## [2.0.1] - 11-15-2018
- Moved the entire site to bootstrap, apply font-awesome icons, work on the interface
- Completed implementation of Device Action Template management, the user is able to create three events that are invoked on the Alarm status of the incoming request and one event that is invoked on the Normal status of the incoming request. Furthermore, Device Action Template events utilize timers to support delay and recurring actions
- Fixed bugs in the Device management
- Fixed bugs in the paging component

## [2.0.0] - 10-28-2018
- Integrated TTS generated speech file play into the Monitor interface, this feature should be later enhanced with a queue
- Started to implement Device Action Template management, this feature allows to generate URL events based on incoming HTTP URL requests, for now basic functionality is available to create one URL event with basic information per Device Action Template entry

## [1.7.0] - 08-22-2018
- Added Resource Text-to-speech management to generate speech from text live, speech files will be used to play audio on the Monitor interface
- Completed Device Discovery implementation
- Fixed bugs in the URL Debug interface
- Added paging component to the entire site to provide paging for tables
- Added options to Administrator Configuration interface: image types allowed to upload, maximum image size, default page size

## [1.6.0] - 05-06-2018
- Started to implement a Device Discovery interface, any HTTP URL request that provides Device or Device Type Control that is not yet registered in the system will generate an entry in the Device Discovery interface that the user will be able to fill in with appropriate Facility information and store in the system; basic functionality provided for preview, storing functionality is not available at this point
- Added Device Discovery enable option to Facility and Configuration interfaces, Device Discovery works only when one of the options is enabled

## [1.5.0] - 02-01-2018
- Fixed bugs in the Monitor management
- Fixed bugs in the Facility Management
- Integrated Monitor interface into testing page for easier viewing
- Added Administrator Configuration interface to provide functionality like clear database, clear facility structure, clear devices, clear monitor events, insert test monitor events

## [1.4.0] - 01-15-2018
- Added support for incoming HTTP URL requests to parse into EMS system events and display on the Monitor
- Added web socket support to URL Debug interface to automatically refresh the page when a new event is received
- Added web socket support to Monitor interface to automatically update ongoing event panel information and history panel information
- Moved history panel to the right side of the Monitor interface

## [1.3.0] - 12-05-2017
- Integrated Video and Stream media types to Image, now the Device interface is able to display video or stream specified
- Added selection of Monitor based on facility, utilizing cookie technology to preserve selection between computer recycles and user sessions
- Added Template and History Template management to support pre-defined and user defined monitor event and history cards

## [1.2.1] - 09-10-2017
- Started to add a monitor system to display all the ongoing events and some short history
- Added Monitor management which utilizes the grid system to arrange events on the page as pre-defined static cards and history scroll at the bottom
- Added Media Type interface to introduce video and stream for cameras
- Integrated Media type to Image, for now just the Image Media Type, later we can add both Video and Stream media types to support camera and other video/url enhanced devices

## [1.2.0] - 07-15-2017
- Moved image support from Device management to a separate module. Create Image management with Image Type and Image interfaces, where Image Type right now is just Device, and rather than uploading images for devices the user can select an image from a pre-defined image gallery
- Integrated Image library to Device management
- Extended testing interface with Device Type Controls for the selected device, Action to send (on/off), GET/POST, JSON
- Bug fixes in the Device management

## [1.1.0] - 06-13-2017
- Added Device management, device represents an external system that is able to generate and send events via HTTP URL. A device must be attached to a facility and a room as it is always physically placed in one spot
- Integrated Type and Type Control into Device management and rename to Device Type and Device Type Control
- Integrated Device selection into testing interface
- Added image support to Device management

## [1.0.2] - 04-22-2017
- Added Resource Text Type and Resource Text interfaces that store text information; integrated Resource Text to the testing interface, when a resource text is selected, it’s added to the URL under an appropriate key
- Added Type and Type Control management, these can represent signals, buttons, events or other similar occurrences in the installed system environment, ie: a pull cord, a door lock, a heart rate monitor alarm etc. The idea is to attach an occurrence to a Type and Type Control and display to the user in some form. Due to architectural difficulties, the Type Control is limited to 8 per each Type
- Bug fixes in the facility management

## [1.0.1] - 03-17-2017
- Integrated address into the facility management
- Further expanding facility structure, added room interface; made linking between all objects of the facility structure
- Started to implement a testing interface to send HTTP URL’s with filled information to the already existing URL Debug interface; right now we can manually type a request URL and also pick parameters from the lists of facility, department and floor
- Implemented a facility structure filtering component that’s used throughout the entire site; ie when selecting a specific floor or department, it will display rooms that belong to that floor or department

## [1.0.0] - 02-22-2017
- Started to create a facility structure, added interfaces for facility, floors, and departments management
- Added address management interface, make use of already existing country and state/province; for future use in the facility interface
- Added IP address blacklist user interface for basic security

## [0.0.1] - 01-20-2017
- Created user management with user management interface, authorization page, and rights based on the user roles
- Created API to receive events via HTTP URL requests
- Added user URL Debug interface to parse incoming API requests and display in table format
- Added basic portal settings including country, state/province

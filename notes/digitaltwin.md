## Digital Twin
So we could simply send data up to the cloud and store this in a database, and
we could send commands to devices and retry if it fails. But with a digital
twin there is an API which receives the latest state and likewise when sending
commands to the device the digital twin will take care of the buffering and
resending.

We have connectivity, a stream of data which is stored in kafka. We want to be
able to provide the user with the state of the device, but we might want to
send only the data that is updated and not the complete state. But a user is
most probably interested in the latest known state for the device. There is a
schema for the data. So we don't just have blobs but structured data which we
can use with an API. Simliar to the bluetooth GATT service but for the the
cloud application which clients of the cloud can access.

The digital twin can be a normalizing layer/transformation layer for the
structure that is exposed.

Web of Things can be used for the schema.

Query the state of the twin (this is the cloud side, the other side is the
device itself). Bascially how to extract data from the digital twin.

An important part is the handling of commands that are sent from the cloud, 
and digital twin can take care of the handling of reconsiliation of the state
making sure the data is sent to the device, which might take more that a single
attempt which is something that the user would otherwise need to handle them
self.

## Web of Things
TODO: 


### Eclipse Ditto
Is a digital twin framework written in Java using Akka.

Eclipse  Ditto is ineffcient, why?
Java and Akka, duplicated infrastrature. The serialize alot message which has
performace cost.


### Drogue Iot digital twin
Drogue IoT has an initial digital twin implementation. TODO: take a look at this.
Instead is doing the processing where the digital twin is, i.e it is to sending
the data.


TODO: Take a look at Borsh IoT offerings.




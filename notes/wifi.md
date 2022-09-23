## Wireless Fidelity (WiFi)
The standards are developed by IEEE. WiFi has two frequencies 2.4 GHz and 5 GHz.

WiFi routers can be single or dual-band (supporting both frequencies).

### Standards
In 1997 the IEEE created a standard named 802.11 which had a speed of 2Mbps. The
The names of the developed standards all followed the same name 802.11 with one
or two letter suffixes. I've always been confused with this naming and it sound
like other were as well, so there Wi-Fi alliance introduced a new naming scheme
for them which are (Wi-Fi x).

#### 801.11a (Wi-Fi 1)
Was developed in 1999 and had a max speed of 54Mbps. This is useful for
commercial and industry usage. It uses the 5 GHz freq.

#### 802.11b (Wi-Fi 2)
Was also developed in 1999 and has a max speed of 11 Mbps. This is useful for
home and domstic usage. It used the 2.4 GHz freq.

#### 802.11g (Wi-Fi 3)
Was developed in 2003 and combined the properties of a and b. The frequency used
it 2.4 GHz for better coverage. Max speed is 54Mbps.
New name: Wi-Fi 3

#### 802.11n (Wi-Fi 4)
Was introduced in 2009 and operates in both 2.4 and 2.5 GHz (individually) and
provided a data rate of about 600Mbps.

#### 802.11ac (Wi-Fi 5)
Was introduced in 2013 and uses the 5 GHz band. Has a max frequency of 1.3Gbps.
The ranges is shorter due to the usage of 5GHz (compared to 2.4 GHz).

#### 802.11ax (Wi-Fi 6)
Was introduced in 2019 and operates on both 2.4 and 5 GHz for better coverage
and speed. Speeds are up to 10 Gbps.

#### 802.11i Security
TODO: WPA/WPA2

#### 802.11X
TODO: Authenitcation protocol


### Wireless Supplicant
Is a program that is responsible for making login requests to a wireless
network. It passes the login and encryption credentials to an authentication
server.

### Drogue WiFi
I've got a task that enable the usage of https://github.com/embassy-rs/cyw43
with drogue IoT.

There are a few traits in drogue-device/src/traits/wifi.rs:
```rust
pub enum Join<'a> {
    Open,
    Wpa { ssid: &'a str, password: &'a str },
}

pub enum JoinError {
    Unknown,
    InvalidSsid,
    InvalidPassword,
    UnableToAssociate,
}

pub trait WifiSupplicant {
    type JoinFuture<'m>: Future<Output = Result<IpAddr, JoinError>>
    where
        Self: 'm;
    fn join<'m>(&'m mut self, join: Join<'m>) -> Self::JoinFuture<'m>;
}
```

### Access Point (ap)
This mode means that the device is acting like a wireless router and has an
SSID. So another device will be able to connect to it.


### Station (sta)
This mode means that the device can act as a wireless client and connect to
a wireless router.

### Service Set ID (SSID)
This is a unique name for a WLAN on a network. This is what we specify when we
want to join a network.



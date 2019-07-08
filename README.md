# oereb-kataster-prototyp

```
http://localhost:8080/versions/xml

http://localhost:8080/capabilities/xml
```


```
#cloud-config
users:
  - name: oerebuser
    shell: /bin/bash

package_upgrade: false

runcmd:
 - apt update
 - wget -qO - https://adoptopenjdk.jfrog.io/adoptopenjdk/api/gpg/key/public | sudo apt-key add -
 - add-apt-repository --yes https://adoptopenjdk.jfrog.io/adoptopenjdk/deb/
 - apt-get install --yes adoptopenjdk-8-hotspot
 - usermod -aG docker oerebuser 
 - mkdir -p /opt/oereb-pgdata
 - chown -R oerebuser:oerebuser /opt/oereb-pgdata
 - git clone https://github.com/edigonzales/oereb-kataster-prototyp.git /home/oerebuser/oereb-kataster-prototyp
 - chown -R oerebuser:oerebuser /home/oerebuser/oereb-kataster-prototyp
```


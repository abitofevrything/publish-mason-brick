FROM dart:stable

COPY pubspec.* /
RUN dart pub get -C /

COPY . /
RUN dart pub get --offline -C /

CMD [ "dart", "run", "/main.dart" ]

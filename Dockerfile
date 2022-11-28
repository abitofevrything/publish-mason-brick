FROM dart:stable

COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline

CMD [ "dart", "run", "main.dart" ]

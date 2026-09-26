// GENERATED CODE - DO NOT MODIFY BY HAND
// Généré manuellement selon le format standard de hive_generator
// (régénérable normalement via `dart run build_runner build`).

part of 'weather_cache_model.dart';

class WeatherCacheModelAdapter extends TypeAdapter<WeatherCacheModel> {
  @override
  final int typeId = 1;

  @override
  WeatherCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeatherCacheModel(
      cityName: fields[0] as String,
      country: fields[1] as String,
      temperature: fields[2] as double,
      feelsLike: fields[3] as double,
      tempMin: fields[4] as double,
      tempMax: fields[5] as double,
      humidity: fields[6] as int,
      windSpeed: fields[7] as double,
      description: fields[8] as String,
      iconCode: fields[9] as String,
      pressure: fields[10] as int,
      fetchedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WeatherCacheModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.cityName)
      ..writeByte(1)
      ..write(obj.country)
      ..writeByte(2)
      ..write(obj.temperature)
      ..writeByte(3)
      ..write(obj.feelsLike)
      ..writeByte(4)
      ..write(obj.tempMin)
      ..writeByte(5)
      ..write(obj.tempMax)
      ..writeByte(6)
      ..write(obj.humidity)
      ..writeByte(7)
      ..write(obj.windSpeed)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.iconCode)
      ..writeByte(10)
      ..write(obj.pressure)
      ..writeByte(11)
      ..write(obj.fetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

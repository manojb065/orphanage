library orphanage.global;

Map<String, dynamic> data = new Map<String, dynamic>();

void appDataSet(String key, dynamic value) {
  data[key] = value;
}

dynamic appDataGet(String key) {
  return data[key];
}

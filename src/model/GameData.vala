class GameData {
  public Version factorio_version;
  public Version base_version;
  public string mods_path;

  public GameData(string game_path) {
    mods_path = game_path + "mods/";

    File base_data_file = File.new_for_path(game_path + "data/base/info.json");
    DataInputStream dis = new DataInputStream(base_data_file.read());
    string base_data_string = "";
    string line;
    while ((line = dis.read_line(null)) != null) base_data_string += line;
    dis.close();

    Json.Object base_data = Json.from_string(base_data_string).get_object();

    base_version = new Version.from_string(base_data.get_string_member ("version"));
    factorio_version = new Version (base_version.major, base_version.minor, 0);
  }
}
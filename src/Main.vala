

void main() {
  Soup.Session soup_session = new Soup.Session();
  FactorioAPI api = new FactorioAPI(soup_session);

  print("-Enter data- \n");
  print(" Factorio path : ");
  string factorio_path = stdin.read_line();

  print(" Mod id        : ");
  string mod_id = stdin.read_line();


  GameData game_data = new GameData(factorio_path);
  Mod mod = api.get_mod(mod_id);

  print("-Supported releases-\n");
  foreach (ModRelease release in mod.releases) {
    if (
      release.factorio_version.equal(game_data.factorio_version) &&
      game_data.base_version.greeter_equal(release.base_version)
    ) {
      print(" %s\n", release.version.to_string());
    }
  }

  print("Select release : ");
  Version mod_version = new Version.from_string(stdin.read_line());
  
  List<Dependence> all = mod.all_mods(game_data, api, mod_version);

  print("Downloading...");
  foreach (var dep in all) {
    api.get_mod(dep.mod_id).download(game_data, dep.mod_version);
  }
}

class FactorioAPI {
  private Soup.Session soup_session;
  private HashTable<string, Mod> cache;

  public FactorioAPI(Soup.Session session) {
    soup_session = session;
    cache = new HashTable<string, Mod>(str_hash, str_equal);
  }

  public Mod get_mod(string id) {

    if (cache.contains(id)) return cache.get(id);

    Array<ModRelease> releases;
    string name;
    string summary;
    
    Soup.Message msg = new Soup.Message("GET", "https://mods.factorio.com/api/mods/%s/full".printf(id));
    if (soup_session.send_message(msg) == 404) {
      throw new ResourceError.NOT_FOUND("Can't get mod!");
    }

    Json.Object response = Json.from_string((string)(msg.response_body.data)).get_object();

    name = response.get_string_member("name");
    summary = response.get_string_member("summary");

    releases = new Array<ModRelease>();
    Json.Array releases_data = response.get_array_member("releases");

    for (int i = 0; i < releases_data.get_length(); i++) {
      Json.Object release_data = releases_data.get_object_element(i);
      ModRelease release = new ModRelease();
      release.mod_id = id;

      release.version = new Version.from_string(release_data.get_string_member("version"));
      release.factorio_version = new Version.from_string(release_data.get_object_member("info_json").get_string_member("factorio_version"));

      Json.Array dependencies_data = release_data.get_object_member("info_json").get_array_member("dependencies");

      for (int j = 0; j < dependencies_data.get_length(); j++) {
        Dependence dependence = new Dependence.from_string(dependencies_data.get_string_element(j));

        if (dependence.mod_id == "base") {
          release.base_version = dependence.mod_version;
          continue;
        }

        release.dependencies.append_val(dependence);
      }

      releases.append_val(release);
    }

    Mod mod = new Mod(id, name, summary, releases);
    cache.set(id, mod);
    return mod;
  }
}
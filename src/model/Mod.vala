class ModRelease {
  public Array<Dependence> dependencies;
  public Version factorio_version;
  public Version ?base_version;
  public Version version;
  public string mod_id;

  public ModRelease() {
    dependencies = new Array<Dependence>();
    factorio_version = new Version.from_string("0.0");
    base_version = null;
    version = new Version.from_string("0.0");
    mod_id = "";
  }
}
  
class Mod {
  public Array<ModRelease> releases;
  public string id;
  public string name;
  public string summary;

  public Mod(string mod_id, string mod_name, string mod_summaty, Array<ModRelease> mod_releases) {
    id = mod_id;
    name = mod_name;
    summary = mod_summaty;
    releases = mod_releases;
  }

  public void download(GameData game_data, Version version) {
    foreach (var release in releases) {
      if (release.version.equal(version)) {
        File mod = File.new_for_uri("https://mods-storage.re146.dev/%s/%s.zip".printf(id, version.to_string()));
        GLib.FileIOStream io;
        File tmpFile = File.new_tmp(null, out io);
        mod.copy(tmpFile, OVERWRITE);

        Archive.Read read = new Archive.Read();
        read.support_format_all();
        read.support_filter_all();
        read.open_filename(tmpFile.get_path(), 10240);

        unowned Archive.Entry entry;
        while (read.next_header (out entry) == Archive.Result.OK) {
          entry.set_pathname(game_data.mods_path + entry.pathname());
          read.extract(entry);
        }

        return;
      };
    }
  }

  public List<Dependence> all_mods(GameData game_data, FactorioAPI api, Version version) {
    List<Dependence> deps_for_check = new List<Dependence>();
    List<Dependence> checked_deps = new List<Dependence>();

    deps_for_check.append(new Dependence(id, version, true, false));

    for (uint i = 0; i < deps_for_check.length(); i++) {
      Dependence dep = deps_for_check.nth_data(i);
      Mod dep_mod = api.get_mod(dep.mod_id);
      ModRelease ?release = null;

         
      foreach (ModRelease maybe_release in dep_mod.releases) {
        if (maybe_release.version.equal(dep.mod_version)) {
          release = maybe_release;
          break;
        }
      }

      if (release == null) throw new OptionError.BAD_VALUE("Mod %s don't have v%s", dep.mod_id, dep.mod_version.to_string());
      

      foreach (Dependence new_dep in release.dependencies) {
        if (!new_dep.required || new_dep.conflict) continue;

        Mod new_dep_mod = api.get_mod(new_dep.mod_id);

        if (new_dep.mod_version == null) {
          new_dep.mod_version = new_dep_mod.releases.index(0).version;
        }

        bool found_release = false;
        foreach (ModRelease dep_release in new_dep_mod.releases) {

          found_release = dep_release.version.greeter_equal(new_dep.mod_version) && game_data.factorio_version.equal(dep_release.factorio_version);
          if (dep_release.base_version != null) {
            found_release = found_release && game_data.base_version.greeter_equal(dep_release.base_version);
          }

          if (found_release) {
            new_dep.mod_version = dep_release.version;
            break;
          }
        }

        if (!found_release) throw new OptionError.FAILED("Mod %s don't have suitable release.", new_dep.mod_id);

        bool need_add = true;

        foreach (Dependence checked_dep in checked_deps) {
          if (checked_dep.mod_id == new_dep.mod_id) {
            need_add = false;

            if (!checked_dep.mod_version.greeter_equal(new_dep.mod_version)) {
              checked_dep.mod_version = new_dep.mod_version;
            }
          }
        }

        if (need_add)deps_for_check.append(new_dep);
      }

      checked_deps.append(dep);
    }

    return checked_deps;
  }
}
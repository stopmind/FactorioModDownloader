class Dependence {
  public Version ?mod_version;
  public string mod_id;
  public bool required;
  public bool conflict;

  public Dependence.from_string(string dependence) {
    string clear_dependence = dependence;
  
    clear_dependence = clear_dependence.replace(")", "");
    clear_dependence = clear_dependence.replace("(", "");
    clear_dependence = clear_dependence.replace("~", "");
  
    required = !clear_dependence.has_prefix("?");
    conflict = clear_dependence.has_prefix("!");
  
    clear_dependence = clear_dependence.replace("!", "");
    clear_dependence = clear_dependence.replace("?", "");
  
    if (clear_dependence.split(">=").length == 2) {
      mod_id = clear_dependence.split(">=")[0];
      mod_version = new Version.from_string(clear_dependence.split(">=")[1]);
    } else {
      mod_id = clear_dependence;
    }
  
    if (mod_id.has_prefix(" ")) {
      mod_id = mod_id.substring(1, -1);
    }
    if (mod_id.has_suffix(" ")) {
      mod_id = mod_id.substring(0, mod_id.length-1);
    }
  }

  public Dependence(string id, Version ver, bool required, bool conflict) {
    mod_id = id;
    mod_version = ver;
    this.required = required;
    this.conflict = conflict;
  }
}

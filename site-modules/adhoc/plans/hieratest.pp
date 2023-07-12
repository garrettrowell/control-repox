# This is a description for my plan
plan adhoc::hieratest(
  # input parameters go here
  TargetSpec $targets,
  String $lookup_secret,
) {

  # lookup the desired secret on the primary server because we assume the actual target(s) won't have a puppet agent
  $secret_block = apply(get_target('pe-primary.garrett.rowell')) {
    notify { $lookup_secret:
      message => "${lookup($lookup_secret).unwrap}"
    }
  }
  # take advantage of only ONE result block with that always creates ONE corrective change
  $retrieved_secret = $secret_block.to_data[0]['value']['report']['resource_statuses']["Notify[${lookup_secret}]"]['events'][0]['desired_value']

  #purely for development...
  out::message($retrieved_secret)

}

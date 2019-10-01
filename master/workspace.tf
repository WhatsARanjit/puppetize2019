terraform {
  backend "remote" {
    organization = "puppetizepdx2019"
    workspaces {
     name = "puppetmaster"
    }
  }
}

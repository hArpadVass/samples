# samples
///
#import employee.Potential

#class ExampleWork {

  let owner          : IosDeveloper
  var pastEmployeers : [Employeer] 
  var skills         : [String]
  
  init(){
    self.owner = IosDeveloper(name: "Hayden", age: 28)
    self.pastEmloyeers = [
      Employeer( name : "US Army / NSA", yearsActive : 4),
      Employeer( name : "BubblyNet", yearsActive : 1)
    ]
    self.skills = ["Swift"
      , "Java"
      , "C#"
      , "Agile Development
      , "JSON"
      , "Bluetooth Mesh"
      , "Git"
      , "Data Analytics
      , "Critical Thinking"
      , "Problem Solving"]
      
      presentWelcomeMessage(){
        print("Thanks for look'in!")
      }
  }
  
  
  func presentWelcomeMessage(completion : ()->()){
    print("Hello! Welcome to my small but humble GitHub. I update it with a few pieces of work I did in the past    month. This is mostly for potential employeers but I also have a quite bit of experience in Bluetooth Mesh and beaconing. I'm totally willing to give a hand to whomever is interested.")
    completion()
  }
}

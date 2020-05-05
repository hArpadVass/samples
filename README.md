# samples

import employee.Potential  
<br />
class ExampleWork {  
  <br />
  let owner          : IosDeveloper
  <br />
  var pastEmployeers : [Employeer] 
  <br />
  var skills         : [String]
  <br />
  
  init(){
  <br />
    self.owner = IosDeveloper(name: "Hayden", age: 28)
    <br />
    self.pastEmloyeers = [<br />
      Employeer( name : "US Army / NSA", yearsActive : 4),
      <br />
      Employeer( name : "BubblyNet", yearsActive : 1)
    ]
    <br />
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
      <br />
      presentWelcomeMessage(){
        print("Thanks for look'in!")
      }
  }
  
  
  func presentWelcomeMessage(completion : ()->()){
    print("Hello! Welcome to my small but humble GitHub. I update it with a few pieces of work I did in the past    month. This is mostly for potential employeers but I also have a quite bit of experience in Bluetooth Mesh and beaconing. I'm totally willing to give a hand to whomever is interested.")
    completion()
  }
}

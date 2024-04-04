      $(document).ready(function() {
        console.log("loaded");
        
        $(document).on("click", ".answer-toggle", function() {
          console.log("hello");
          $(this).closest(".answer-box").find(".answer").toggle();
        });
        
        $("#submitAnswers").click(function() {
          $(".answer").show();
          var selectedValues = [];
          $("input[type=radio]:checked").each(function() {
            selectedValues.push($(this).val());
          });
          Shiny.setInputValue("selectedValues", selectedValues);
          console.log("hi");
        });
        
        Shiny.addCustomMessageHandler("showCheckmark", function(ind) {
          $("#checkmark" + ind).show();
          $("#x" + ind).hide();
        });
        
        Shiny.addCustomMessageHandler("showX", function(ind) {
          $("#x" + ind).show();
          $("#checkmark" + ind).hide();
        });
        
        function resetRadioButtons() {
          $('input[type="radio"]').prop('checked', false);
        }
        
        function resetAnswers() {
          $(".answer").hide();
          $(".checkmark").hide();
          $(".x").hide();
        }
        
        function filteredReset(ind) {
          console.log(ind);
          console.log(`.q_container${ind}`);
          $(`.q_container${ind}`).hide();

        }
        
        Shiny.addCustomMessageHandler("Reset", function(ind) {
          console.log("reset pressed");
          resetRadioButtons();
          resetAnswers();
        });
        
        Shiny.addCustomMessageHandler("filteredReset", function(ind) {
          if(Array.isArray(ind)){
              ind.forEach(function(index) {
              console.log(index);
              filteredReset(index);
            });
          } else {
            filteredReset(ind);
          }

          resetRadioButtons();
          resetAnswers();
          
        });
        
Shiny.addCustomMessageHandler("Test", function(ind) {
    console.log("pressed");
    const request_url = "https://n2q.nick-amato.com/create-checkout-session";
    console.log(request_url);
    fetch(request_url, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            items: [
                {id: 1, quantity: 1},
            ]
        })
    }).then(function(res) {
        if (res.ok) return res.json();
        return res.json().then(function(json) {
            return Promise.reject(json);
        });
    }).then(function({ url }) {
        console.log(url);
        window.location = url;
    }).catch(function(e) {
        console.error(e.error);
    });
});

/*Shiny.addCustomMessageHandler("Login", function(hi) {
    var body = document.body;
    
    // Change the background color
    body.style.background = "black"; // Grey color
    body.style.backgroundSize = "background-size: 100% 100%";
    body.style.color = "white";
  
})*/

      // Function to generate a random number within a range
      function getRandomNumber(min, max) {
          return Math.random() * (max - min) + min;
      }

      // Function to create a star element
      function createStar() {
          // Create a new div element for the star
          var star = document.createElement('div');
          star.className = 'star';

          // Set random position for the star
          var x = getRandomNumber(0, window.innerWidth);
          var y = getRandomNumber(0, window.innerHeight);
          star.style.left = x + 'px';
          star.style.top = y + 'px';

          // Add animation properties to the star
          star.style.setProperty('--star-tail-length', getRandomNumber(100, 500) + 'px'); // Random tail length
          star.style.setProperty('--fall-duration', getRandomNumber(5, 15) + 's'); // Random duration
          star.style.setProperty('--fall-delay','0s'); // Random delay

          // Append the star to the stars div
          document.querySelector('.stars').appendChild(star);
      }

      // Function to generate stars
      function generateStars(numStars) {
          for (var i = 0; i < numStars; i++) {
              createStar();
          }
      }

      // Call generateStars function with desired number of stars
      generateStars(100); // Adjust the number of stars as needed

});


        
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

});


        
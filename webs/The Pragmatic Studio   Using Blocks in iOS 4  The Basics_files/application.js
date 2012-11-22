jQuery.noConflict();

// jQuery.ajaxSetup({ 
//   'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
// })

jQuery(function() {
  
  jQuery("a#card_code").click(function () {
    window.open('/card_code.html', '_card_code', 'width=600,height=425'); 
    return false;
  });
  
  jQuery("#comments .spam_report").removeAttr("onclick").click(function () {
    jQuery.post(this.href, null, null, "script");
    return false;
  });
  
  jQuery("#comments .destroy").removeAttr("onclick").click(function () {
    if (confirm("Are you sure you want to destroy this comment?")) {
      jQuery.post(this.href, "_method=delete", null, "script");
    }
    return false;
  });
  
  jQuery.validator.addMethod('cardnumber', function (value, element) { 
      return /^[0-9]{13,16}$/.test(value); 
  }, "Number must be 13-16 digits");
  
  jQuery.validator.addMethod('cardcode', function (value, element) { 
      return this.optional(element) || /^[0-9]{3,4}$/.test(value); 
  }, "Code must be 3-4 digits");
  
  jQuery.validator.addMethod('expired', function (value, element) { 
      var selected_year = jQuery('#expyear').val();   
      var today = new Date();
      var today_year = "" + today.getFullYear();
      if (selected_year == today_year) {
        var today_month = today.getMonth() + 1;
        return value >= today_month; 
      }
      return true;
  }, "Card has expired");
  
  jQuery.validator.addMethod('expmonth', function (value, element) { 
      return /^[01][0-9]$/.test(value); 
  }, "Expiration month must be 2 digits (MM)");
  
  jQuery.validator.addMethod('expyear', function (value, element) { 
      return /^(0[789]|1[0-9])$/.test(value); 
  }, "Expiration year must be 2 digits (YY)");
  
  jQuery("#credit_card").validate({ 
    onkeyup: false,
    onfocusout: false,
    onclick: false,
    onsubmit: true,
    rules: { 
  	  cctype: "required",
  	  cardnumber: {
        required: true,
        cardnumber: true,
        creditcard: true
      },  	 
      cvm: {
        required: true,
        cardcode: true
      }, 
      expmonth: {
        expired: true
      }
  	},
  	messages: { 
  	  cctype: "Card type is required", 
  	  cardnumber: {
  	    required: "Card number is required",
  	    creditcard: "Number isn't valid"
  	  },
  	  cvm: {
  	    required: "Card code is required"
  	  },
  	  expmonth: {
  	    required: "Month is required (MM)"
  	  },
  	  expyear: {
  	    required: "Year is required (YY)"
  	  }
  	}
  });
  
});


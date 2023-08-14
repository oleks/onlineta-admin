async function onlineta_feedback(testName, form, feedbackDiv) {
  const formData = new FormData(form);

  const output = document.getElementById(feedbackDiv);
  output.innerText = "";
  output.parentElement.style.display = "block";

  const spinner = document.getElementById(testName+"-spinner");
  spinner.style.display = "block";

  try {
    const response = await fetch("./grade/" + testName, {
      method: "POST",
      body: formData,
    });
    const result = await response.text();
    spinner.style.display = "none";
    form.reset();

    output.innerText = result;
    console.log("Success");
  } catch (error) {
    spinner.style.display = "none";
    output.innerText = "Error:" + error;
    console.error("Error:", error);
  }
}

function onlineta_ready(fn) {
  if (document.readyState !== 'loading') {
    fn();
    return;
  }
  document.addEventListener('DOMContentLoaded', fn);
}

onlineta_ready(function () {
  const checkBtns = document.querySelectorAll('.onlineta-check');
  checkBtns.forEach((btn) => {
    const testName = btn.dataset.testName;
    const feedbackDiv = btn.dataset.testFeedback;

    btn.addEventListener('click', (e) => {
      e.preventDefault();
      onlineta_feedback(testName, btn.form, feedbackDiv);
    });
  });
});


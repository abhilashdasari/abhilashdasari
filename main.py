from flask import Flask, render_template, send_file
import os

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/download-cv')
def download_cv():
    # This route would serve the CV file if available
    return render_template('index.html')

@app.route('/skills/programming')
def programming_skills():
    return render_template('skills/programming.html')

@app.route('/skills/computational-biology')
def computational_biology():
    return render_template('skills/computational_biology.html')

@app.route('/blog')
def blog():
    posts = [{
        'title': 'Making multi-cohort RNA-seq analyses reproducible',
        'date': 'October 2026',
        'excerpt': 'Practical principles for keeping cohort structure, workflow decisions, and biological interpretation visible throughout a clinical transcriptomics analysis.',
        'route': 'reproducible_multi_cohort_rnaseq'
    }]
    return render_template('blog/index.html', posts=posts)

@app.route('/blog/reproducible-multi-cohort-rnaseq')
def reproducible_multi_cohort_rnaseq():
    return render_template('blog/reproducible-multi-cohort-rnaseq.html')

@app.route('/blog/discovery-grade-research-gap-identification')
def research_gap_blueprint():
    return render_template('blog/research-gap-blueprint.html')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

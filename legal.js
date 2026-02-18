(function () {
  'use strict';

  const SUPPORTED_LOCALES = {
    en: { label: 'العربية', switchTo: 'ar' },
    ar: { label: 'English', switchTo: 'en' }
  };

  const STORAGE_KEY = 'qawam_lang';
  const DEFAULT_LOCALE = 'en';

  const scriptTag = document.querySelector('script[data-page]');
  const PAGE_KEY = scriptTag ? scriptTag.getAttribute('data-page') : 'privacy';

  function qs(selector) { return document.querySelector(selector); }

  function getSavedLocale() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved && SUPPORTED_LOCALES[saved]) return saved;
    } catch (_) {}
    return null;
  }

  function saveLocale(locale) {
    try { localStorage.setItem(STORAGE_KEY, locale); } catch (_) {}
  }

  function detectLocale() {
    const saved = getSavedLocale();
    if (saved) return saved;

    const urlParams = new URLSearchParams(window.location.search);
    const urlLang = urlParams.get('lang');
    if (urlLang && SUPPORTED_LOCALES[urlLang]) return urlLang;

    const browserLang = (navigator.language || '').split('-')[0];
    if (SUPPORTED_LOCALES[browserLang]) return browserLang;

    return DEFAULT_LOCALE;
  }

  async function loadLocale(locale) {
    try {
      const response = await fetch(`locales/${locale}.json`);
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      return await response.json();
    } catch (err) {
      console.error(`Failed to load locale "${locale}":`, err);
      if (locale !== DEFAULT_LOCALE) return loadLocale(DEFAULT_LOCALE);
      return null;
    }
  }

  function renderPage(data, locale) {
    const html = document.documentElement;
    html.setAttribute('lang', data.meta.language);
    html.setAttribute('dir', data.meta.dir);

    const brandEl = qs('#nav-brand-name');
    if (brandEl) brandEl.textContent = data.brandName;

    const langLabel = qs('#lang-label');
    if (langLabel) langLabel.textContent = SUPPORTED_LOCALES[locale].label;

    const backBtn = qs('#back-home');
    if (backBtn) backBtn.textContent = data.legal.backToHome;

    const copyrightEl = qs('#footer-copyright');
    if (copyrightEl) copyrightEl.textContent = data.footer.copyright;

    const pageData = PAGE_KEY === 'terms' ? data.legal.terms : data.legal.privacy;

    document.title = `${pageData.title} — ${data.brandName}`;

    qs('#legal-title').textContent = pageData.title;
    qs('#legal-date').textContent = `${data.legal.lastUpdated}: ${pageData.date}`;
    qs('#legal-intro').textContent = pageData.intro;

    const body = qs('#legal-body');
    body.innerHTML = '';
    pageData.sections.forEach(section => {
      const sectionEl = document.createElement('section');
      sectionEl.className = 'legal__section';
      sectionEl.innerHTML = `<h2 class="legal__heading">${section.heading}</h2>${section.content}`;
      body.appendChild(sectionEl);
    });
  }

  let currentLocale = detectLocale();

  async function switchLocale() {
    const newLocale = SUPPORTED_LOCALES[currentLocale].switchTo;
    const data = await loadLocale(newLocale);
    if (!data) return;
    currentLocale = newLocale;
    saveLocale(newLocale);
    renderPage(data, newLocale);
  }

  async function init() {
    const data = await loadLocale(currentLocale);
    if (!data) return;
    saveLocale(currentLocale);
    renderPage(data, currentLocale);

    qs('#lang-switcher').addEventListener('click', switchLocale);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

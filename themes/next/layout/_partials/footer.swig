<div class="copyright" >
  {% set current = date(Date.now(), "YYYY") %}
  &copy; {% if theme.since and theme.since != current %} {{ theme.since }} - {% endif %}
  <span itemprop="copyrightYear">{{ current }}</span>
  <span class="with-love">
    <i class="fa fa-{{ theme.authoricon }}"></i>
  </span>
  <span class="author" itemprop="copyrightHolder">{{ config.author }}

 &nbsp;&nbsp;|&nbsp;&nbsp;
  <script type="text/javascript">
    var cnzz_protocol = (("https:" == document.location.protocol) ? " https://" : " http://");
    document.write(http://data.zz.baidu.com/urls?site=catalinali.top&token=rmAGtCYijiQ7Shu8' type='text/javascript'%3E%3C/script%3E"));
  </script>
  </span>
</div>

{% if theme.copyright %}
<div class="powered-by">
  {{ __('footer.powered', 'Hexo') }}
</div>

<div class="theme-info">
  {{ __('footer.theme') }} -

</div>

<script>
(function(){
    var bp = document.createElement('script');
    bp.src = '//push.zhanzhang.baidu.com/push.js';
    var s = document.getElementsByTagName("script")[0];
    s.parentNode.insertBefore(bp, s);
})();
</script>

{% endif %}

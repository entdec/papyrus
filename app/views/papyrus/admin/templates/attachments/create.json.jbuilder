# frozen_string_literal: true

json.selector 'div.attachments'
json.html render partial: 'papyrus/admin/templates/attachments/index', layout: false, formats: [:html],
                 locals: { attachments: @template.attachments, upload_url: admin_template_attachments_path(@template) }

class FeedsController < ApplicationController
  before_action :query, only: %i(clean license)

  def all
    # (Warpable.all + Map.all).sort_by(&:created_at)
    @maps = Map.where(status: Map::Status::NORMAL, password: '')
               .joins(%i(user warpables))
               .group('maps.id')
               .order('id DESC')
               .limit(20)
    render(layout: false, template: 'feeds/all')
    response.headers['Content-Type'] = 'application/xml; charset=utf-8'
  end

  def clean
    render(layout: false, template: 'feeds/clean')
    response.headers['Content-Type'] = 'application/xml; charset=utf-8'
  end

  def license
    @maps = @maps.where(license: params[:id])
    render(layout: false, template: 'feeds/license')
    response.headers['Content-Type'] = 'application/xml; charset=utf-8'
  end

  def author
    @author = User.find_by(login: params[:id], status: User::Status::NORMAL)
    @maps = Map.where(author: @author&.login, status: Map::Status::NORMAL, password: '')
              .order('id DESC')
              .joins(:warpables)
              .group('maps.id')
    images = []
    @maps.each do |map|
      images += map.warpables
    end
    @feed = (@maps + images).sort_by(&:created_at)
    render(layout: false, template: 'feeds/author')
    response.headers['Content-Type'] = 'application/xml; charset=utf-8'
  end

  def tag
    @tag = Tag.find_by_name(params[:id])
    @maps = @tag ? @tag.maps.paginate(page: params[:page], per_page: 24) : []
    render(layout: false, template: 'feeds/tag')
    response.headers['Content-Type'] = 'application/xml; charset=utf-8'
  end

  private

  def query
    @maps = Map.order(id: :desc)
              .limit(20)
              .where(status: Map::Status::NORMAL, password: '')
              .joins(:warpables)
              .group('maps.id')
  end
end
